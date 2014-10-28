From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] ovs: Turn vports with dependencies into separate modules
Date: Tue, 28 Oct 2014 21:47:31 +0000
Message-ID: <20141028214731.GA21300@casper.infradead.org>
References: <ab9438abe3e23289db6f850eea9626fe8bd0a969.1413991519.git.tgraf@suug.ch>
 <20141028.144344.398016097830457432.davem@davemloft.net>
 <CAADnVQ+Z6-7sdWAEvHkKR==Nds6hqBfbfPmtUDiZXOTE9DRnGw@mail.gmail.com>
 <20141028.172743.459865270069950735.davem@davemloft.net>
 <CAADnVQK2HRn=XyqF==tuDPFgA5gamVCZmxg5ELVjBX2i0dYwfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38005 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755225AbaJ1Vrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 17:47:33 -0400
Content-Disposition: inline
In-Reply-To: <CAADnVQK2HRn=XyqF==tuDPFgA5gamVCZmxg5ELVjBX2i0dYwfA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/14 at 02:42pm, Alexei Starovoitov wrote:
> On Tue, Oct 28, 2014 at 2:27 PM, David Miller <davem@davemloft.net> wrote:
> >>
> >> it fails the build when lockdep is on:
> >> ERROR: "lockdep_ovsl_is_held" [net/openvswitch/vport-gre.ko] undefined!
> >
> > I've fixed it thusly:
> 
> thanks! that was quick. the fix looks good.

Thanks and sorry for causing this fallout
