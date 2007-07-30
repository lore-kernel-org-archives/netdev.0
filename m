From: Ben Greear <greearb@candelatech.com>
Subject: Re: source interface ping bug ?
Date: Mon, 30 Jul 2007 09:06:10 -0700
Message-ID: <46AE0C72.3020201@candelatech.com>
References: <d39c36500707270130j3eac7f44qb3a4c87496a1296b@mail.gmail.com>	 <d39c36500707290448p599ff710hf79ba1911c818162@mail.gmail.com> <d39c36500707300146h72c72d69rce2f68595bdf6699@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nano bug <linnewbye@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:53446 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752359AbXG3QGL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jul 2007 12:06:11 -0400
In-Reply-To: <d39c36500707300146h72c72d69rce2f68595bdf6699@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nano bug wrote:
> Can someone have a look a this and tell if it's kernel related or if I
> posted this in the wrong place ? Thanks.
>   
Last I checked, ping did not do an SO_BINDTODEVICE even if you did -i ethX.
I think it just looked up the IP for that port and treated it as -i a.b.c.d.

That said, I'm not sure why the behaviour changes for you between kernel
releases.

Maybe an 'strace' of your ping command on the different kernels would help
figure out what the problem is?

Ben

-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


