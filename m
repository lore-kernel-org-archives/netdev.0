From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 03 Aug 2010 16:09:53 +0200
Message-ID: <72ff93eb4581b198faa6ce62d2b5162b@chewa.net>
References: <20100803070426.GN11110@cel.leo> <20100803.001809.25133218.davem@davemloft.net> <87mxt3etut.fsf@basil.nowhere.org> <20100803.060754.26959298.davem@davemloft.net> <20100803133442.GQ11110@cel.leo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:37464 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756470Ab0HCOJy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:09:54 -0400
In-Reply-To: <20100803133442.GQ11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 3 Aug 2010 14:34:43 +0100, Paul LeoNerd Evans=0D
<leonerd@leonerd.org.uk> wrote:=0D
> What if we added a new constant SKF_TRANS_OFF to store the start addr=
ess=0D
> of the transport header, and a new SKF_AD storage area for the transp=
ort=0D
> protocol:=0D
(...)=0D
> Does this sound workable?=0D
=0D
The network header has not been processed by the time the skbuff hits t=
he=0D
packet socket. So the transport header offset is not defined yet.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

