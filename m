From: "Quan Sun" <cfk.quan@gmail.com>
Subject: Different scheduler behavior between 2.4 and 2.6
Date: Tue, 8 May 2007 11:07:34 +0800
Message-ID: <e810d8480705072007i2daa3fc0n9c9570b87435e790@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.238]:27023 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967681AbXEHDHf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2007 23:07:35 -0400
Received: by nz-out-0506.google.com with SMTP id o1so1819535nzf
        for <netdev@vger.kernel.org>; Mon, 07 May 2007 20:07:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
   Recently I met a problem on different scheduler behavior between
2.4.22 and 2.6.18.8.
   The application works as a proxy, it listen on an interface,
connect through another interface. This application works on a box
with two Xeon cpu, each of them is hyper-threading.
   On 2.4.22, CPU0 serve interrupts, the application works on other
three CPUs.
   But on 2.6.18.8, if I turn on 'noirqbalance' kernel parameter, and no
irqbalance  process, the application will stuck to CPU0 as well as interrupts
after several seconds' working. Then there will be a 0% idle cpu, and
three 100%idle CPUs.

  /proc/interrupt shows all eths's interrupts are working at CPU0.

  It seems that scheduler ignores the working load of interrupts.

   My question is, is there a way to tune 2.6 kernel working as 2.4?
Just one cpu for interrupts, other three cpu for normal work.

-- 
wonvoo
