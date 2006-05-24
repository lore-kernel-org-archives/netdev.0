From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Wed, 24 May 2006 08:04:49 -0700
Message-ID: <20060524080449.2c81dc38@localhost.localdomain>
References: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <jmorris@namei.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:52104 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932320AbWEXPFC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 11:05:02 -0400
To: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
In-Reply-To: <A975FFC51622704CBEAB749E263D1799015540B3@mail01.student.main.ntu.edu.sg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006 19:08:05 +0800
"#ZHOU BIN#" <ZHOU0022@ntu.edu.sg> wrote:

> From: Bin Zhou <zhou0022@ntu.edu.sg>
> 
> TCP Veno module is a new congestion control module to improve TCP performance over wireless networks. The key innovation in TCP Veno is the enhancement of TCP Reno/Sack congestion control algorithm by using the estimated state of a connection based on TCP Vegas. This scheme significantly reduces "blind" reduction of TCP window regardless of the cause of packet loss.
> 
> This work is based on the research paper "TCP Veno: TCP Enhancement for Transmission over Wireless Access Networks." C. P. Fu, S. C. Liew, IEEE Journal on Selected Areas in Communication, Feb. 2003.
> 
> Original paper and many latest research works on veno can be reached at http://www.ntu.edu.sg/home/ascpfu/veno/veno.html  or through the www.google.com by entering keywords "TCP Veno"
> 
> 
> 
> Sign-off-by: Bin Zhou <zhou0022@ntu.edu.sg>
> 	         Cheng Peng Fu <ascpfu@ntu.edu.sg>

I will put this in my tcp git tree (along with LP and Compound).
Hope you don't mind if I will run it through Lindent first to cleanup whitespace.
