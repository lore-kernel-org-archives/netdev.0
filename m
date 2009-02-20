From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: 2.6.29-rc5-git3 Leak r=1 3
Date: Fri, 20 Feb 2009 13:49:47 +0200
Message-ID: <200902201349.47984.denys@visp.net.lb>
References: <200902192304.35547.denys@visp.net.lb> <Pine.LNX.4.64.0902201006110.31742@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: "Ilpo =?iso-8859-1?q?J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:50106 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbZBTLtz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 06:49:55 -0500
In-Reply-To: <Pine.LNX.4.64.0902201006110.31742@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday 20 February 2009 10:09:51 Ilpo J=E4rvinen wrote:
> On Thu, 19 Feb 2009, Denys Fedoryschenko wrote:
> > If it is interesting for anybody, on loaded proxy server, at beginn=
ing:
> >
> > [   21.587816] netconsole: remote ethernet address 00:04:23:af:02:c=
a
> > [   21.591028] console [netcon0] enabled
> > [   21.591486] netconsole: network logging started
> > [   23.942232] sd 11:0:0:0: [sda] 1146040320 512-byte hardware sect=
ors:
> > (586 GB/546 GiB)
> > [   23.943077] sd 11:0:0:0: [sda] Write Protect is off
> > [   23.943138] sd 11:0:0:0: [sda] Mode Sense: 06 00 10 00
> > [   23.943182] sd 11:0:0:0: [sda] Write cache: enabled, read cache:
> > enabled, supports DPO and FUA
> > [  239.315726] Leak r=3D1 3
>
> This is a local tcp sender counting retrans_out incorrectly. I'll try=
 to
> go through the recent changes as soon as I get some free time.

Here is few more appearing, maybe will be useful in future.

[43028.945806] Leak r=3D1 3
[43249.983868] Leak r=3D1 3
[44459.941476] Leak r=3D1 3
[45853.641072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk wi=
ndow=20
1905466446:1905480750 (repaired)
[45854.477072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk wi=
ndow=20
1905466446:1905480750 (repaired)
[45856.149072] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk wi=
ndow=20
1905466446:1905480750 (repaired)
[45859.493081] TCP: Peer 172.16.193.87:1259/8080 unexpectedly shrunk wi=
ndow=20
1905466446:1905480750 (repaired)
[48607.714833] Leak r=3D3 1
[48936.032533] Leak r=3D1 3
[52018.429549] Leak r=3D1 1

