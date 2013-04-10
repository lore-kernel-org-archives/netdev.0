From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: be2net: GRO for non-inet protocols
Date: Wed, 10 Apr 2013 15:53:37 +0200
Message-ID: <20130410135337.GD7147@eerihug-hybrid.ki.sw.ericsson.se>
References: <20130405132007.GF7551@eerihug-hybrid.ki.sw.ericsson.se>
 <1365175702.3405.2.camel@edumazet-glaptop>
 <1365175872.3405.3.camel@edumazet-glaptop>
 <20130408064010.GD8543@eerihug-hybrid.ki.sw.ericsson.se>
 <20130408152417.GD19951@eerihug-hybrid.ki.sw.ericsson.se>
 <ffc6a5aa-11f5-4e25-b6ac-e1596e8d5437@CMEXHTCAS1.ad.emulex.com>
 <20130409163108.GA6818@eerihug-hybrid.ki.sw.ericsson.se>
 <9982e479-7a8c-4520-999b-9fb59dc62689@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"Perla, Sathya" <Sathya.Perla@Emulex.Com>,
	"Seetharaman, Subramanian" <subbu.seetharaman@emulex.com>,
	"Khaparde, Ajit" <Ajit.Khaparde@Emulex.Com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Bandi,Sarveshwar" <Sarveshwar.Bandi@Emulex.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw2.ericsson.se ([193.180.251.37]:64904 "EHLO
	mailgw2.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443Ab3DJN6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Apr 2013 09:58:44 -0400
Content-Disposition: inline
In-Reply-To: <9982e479-7a8c-4520-999b-9fb59dc62689@CMEXHTCAS2.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 10, 2013 at 01:46:53PM +0000, Bandi,Sarveshwar wrote:
> Can you check if packets are garbled when using netif_receive_skb?
> Or it happens only when napi_gro_receive is used?

Yes, all received packets are OK when netif_receive_skb is used.
It's only when napi_gro_receive is used (from the context of be_rx_compl_process,
as per Eric's patch) that i get the corrupted packets.

//E
