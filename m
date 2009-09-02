From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: about packets forwarding
Date: Wed, 2 Sep 2009 06:14:21 -0700 (PDT)
Message-ID: <128535.30433.qm@web111606.mail.gq1.yahoo.com>
References: <f4f837ab0907220706g1129a1cbv7dfad944e5bada16@mail.gmail.com> <f4f837ab0909020127o3359ed03j224ef51a0673bcd9@mail.gmail.com> <f4f837ab0909020203w67bcba16pbb317c587c58e70f@mail.gmail.com> <20090902201800.1dbb4988.lk-netdev@lk-netdev.nosense.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: Mark Smith <lk-netdev@lk-netdev.nosense.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from n8.bullet.re3.yahoo.com ([68.142.237.93]:40789 "HELO
	n8.bullet.re3.yahoo.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751725AbZIBNOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2009 09:14:19 -0400
In-Reply-To: <20090902201800.1dbb4988.lk-netdev@lk-netdev.nosense.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





> Hello,
> 
> I have something to ask here.
> 
> The topology of the network is as follows.
> There are six Nodes (A, B, C, D, M, N).
> 
>   M
>   |
>   A
>  / \
> B   D
>  \ /
>   C
>   |
>   N
> 
> M-A, C-N are wired links.
> A-B, B-C, A-D, D-C are wireless links.
> 
> Node M wnats to communicate with node N. Because the wireless links
> are not very reliable, I want to forward the packets through A-B-C and
> A-D-C simultaneously (When Node A receives packets(from Node M) from
> its wired interface eth0, It will forward the same packets to its
> wireless interfaces wlan0 and wlan1 simultaneously) . How to implement
> this?
> 

------
Stephen Hemminger  <shemminger@linux-foundation.org> said,

* The traffic control command 'tc filter    mirred'  probably does this, but not sure.
* Other way to do the same thing would be iptables, not sure if there is an iptables target to mirror.
------

Can you give more information about how to implement this?


      

