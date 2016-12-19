From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net] virtio_net: reject XDP programs using header
 adjustment
Date: Mon, 19 Dec 2016 15:23:52 +0000
Message-ID: <BL2PR07MB2306FB78FBB5F2D17681699D8D910@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "kafai@fb.com" <kafai@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "mst@redhat.com" <mst@redhat.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0055.outbound.protection.outlook.com ([104.47.41.55]:30503
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932170AbcLSPXy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Dec 2016 10:23:54 -0500
In-Reply-To: <20161219150500.2600-1-jakub.kicinski@netronome.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
> added a new XDP helper to prepend and remove data from a frame.
> Make virtio_net reject programs making use of this helper until proper
> support is added.
>=20
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Is that how it goes until we'll add the proper infrastructure?
Am I expected to provide the same for qede?

I was under the impression that so long as this is being [early] developed
and there's no way to communicate what is and isn't supported by
a given implementation, it would simply be the user's responsibility
to make sure what he's trying is supported.
