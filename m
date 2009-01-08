From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!     2.6.28
Date: Thu, 8 Jan 2009 20:41:58 +0200
Message-ID: <200901082041.58597.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <3226.192.168.1.3.1231435651.squirrel@webmail.decimal.pt> <200901082032.16859.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:38284 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756912AbZAHSlw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:41:52 -0500
In-Reply-To: <200901082032.16859.denys@visp.net.lb>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I check, also HFSC not keeping bandwidth accurate.
Seems i am totally lost, what to do.
Any ideas what i can try?

On Thursday 08 January 2009 20:32:16 Denys Fedoryschenko wrote:
> I disable tso/gso and others. No difference at all. Here is actual output,
> after running it for 1-2 minutes.
>
> Cisco
>   30 second output rate 59600000 bits/sec, 32978 packets/sec
> Linux
>
> class htb 1:33 parent 1:10 leaf 33: prio 0 rate 1000Kbit ceil 57000Kbit
> burst 2849b cburst 72838b
>  Sent 63746261 bytes 492929 pkt (dropped 0, overlimits 0 requeues 0)
>  rate 61200bit 48pps backlog 0b 0p requeues 0
>  lended: 491208 borrowed: 1721 giants: 0
>  tokens: 21453 ctokens: 9971
>
> class htb 1:32 parent 1:10 leaf 32: prio 0 rate 4000Kbit ceil 57000Kbit
