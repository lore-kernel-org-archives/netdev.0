From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH] dccp: remove module exit functions
Date: Mon, 13 Nov 2006 13:41:20 +0000
Message-ID: <200611131341.20676@strip-the-willow>
References: <XMMS.LNX.4.64.0611100345300.10983@d.namei> <XMMS.LNX.4.64.0611101126150.15046@d.namei> <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "James Morris" <jmorris@namei.org>, netdev@vger.kernel.org,
	"dccp (vger)" <dccp@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:40417 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1754635AbWKMNlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Nov 2006 08:41:36 -0500
To: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
In-Reply-To: <39e6f6c70611101032v5f0be644ta65069cf533b3385@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On 11/10/06, James Morris <jmorris@namei.org> wrote:

|  > I wonder if this facility can be integrated more generally into the kernel
|  > as a kernel hacking option, as this is not the only protocol which people
|  > are developing.
|  >
|  
|  See:
|  http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
|  
|  This one requires a bit more thinking, so I'm postponing it for now to
|  get the simple bits in Gerrit's patch queue cherrypicked and sent for

There is a similar problem in sctp and so it would indeed be useful to have a (configuration)
option. Without the `unload hack' there is no module unloading and that is very bad, especially
since DCCP development is likely to continue (there is no single consistent, full DCCP implementation
yet, so testing will be one prime activity).
