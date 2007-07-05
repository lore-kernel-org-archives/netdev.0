From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: Via Rhine II Network Card Failure
Date: Thu, 5 Jul 2007 16:42:31 +0530
Message-ID: <a781481a0707050412t4da2d732p83cb219695f52457@mail.gmail.com>
References: <665527d90706210358k5a1d27f2r30536547f447a516@mail.gmail.com>
	 <20070704121141.GA3996@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Mark Hannessen" <markhannessen@gmail.com>, netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:4817 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758538AbXGELMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jul 2007 07:12:32 -0400
Received: by an-out-0708.google.com with SMTP id d31so512950and
        for <netdev@vger.kernel.org>; Thu, 05 Jul 2007 04:12:32 -0700 (PDT)
In-Reply-To: <20070704121141.GA3996@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/4/07, Jarek Poplawski <jarkao2@o2.pl> wrote:
> On 21-06-2007 12:58, Mark Hannessen wrote:
> > [...]
> > SIOCSIFADDR: No such device eth0:
> > ERROR while getting interface flags: No such device
> [...]
> - is eth0 shown in /proc e.g. in /proc/interrupts?
> - is ifconfig -a returning something?
> - can you try ip (from iproute package) e.g. ip link set eth0 up
> - do you have the same net options enabled as in this distro:
>   e.g. CONFIG_PACKET?
> - maybe you can try to figure something after (as root):
>   strace ifconfig eth0 up
> or send the output here...

BTW that "No such device eth0" is generally a case of
module not loaded / something wrong with modprobe.conf
Mark, are you sure those kind of issues can be ruled out?

Satyam
