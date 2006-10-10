From: "Ronghua Zhang" <ronghuazhang@gmail.com>
Subject: is each frag of a skb always less than 1 page?
Date: Tue, 10 Oct 2006 15:37:04 -0700
Message-ID: <ba020e9f0610101537m492a957fj982097c8d7f407e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:27072 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1030608AbWJJWhF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Oct 2006 18:37:05 -0400
Received: by py-out-1112.google.com with SMTP id 57so22630pya
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2006 15:37:05 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>From the code of tcp_sendmsg, it seems to me that each frag is at most
one page. Is it a guaranteed property or the driver should not assume
it? Thanks

Ronghua
