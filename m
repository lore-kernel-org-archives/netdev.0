From: "Denys" <denys@visp.net.lb>
Subject: Re: strange TCP behaviour
Date: Tue, 8 May 2007 13:31:32 +0300
Message-ID: <20070508103049.M75995@visp.net.lb>
References: <20070508094330.M22276@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: "Denys" <denys@visp.net.lb>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:44472 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966365AbXEHKbo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2007 06:31:44 -0400
In-Reply-To: <20070508094330.M22276@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I forgot to mention, latest tested kernel (for now)
2.6.21-rc5
It's just not easy to upgrade, is there any changes after rc5 related to that?

On Tue, 8 May 2007 12:49:36 +0300, Denys wrote
> Dear All
> 
> I have application, thats accept redirected requests from squid 
> (over iptables .... -j REDIRECT), getting ip over 
> getsockopt/SO_ORIGINAL_DST and throwing data in to the tunnel.
> 
> And i have strange behaviour, when i do
> sysctl net.ipv4.tcp_frto=0
> 
> And i try any website with attachments (means a lot of data going to 
> be sent to redirect), i am getting after 3-10 seconds message "Read 
> error: Connection timed out". Thats a bit strange, possible it is 
> related to application, but i guess kernel must not give error to 
> recv/read (i dont know what squid is using). It is a bit difficult 
> to reproduce the problem, but i can give a remote access to PC where 
> all things installed. But i have no idea, who of TCP(?) maintainers 
> can help me with this. I think there is no app problem, tcpdump 
> looks normal, there is no reset(and message will be different in 
> case of reset).
> 
> --
> Denys Fedoryshchenko
> Technical Manager
> Virtual ISP S.A.L.
> 
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

