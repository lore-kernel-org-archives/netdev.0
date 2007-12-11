From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6 support for NFS server
Date: Tue, 11 Dec 2007 11:41:24 -0500
Message-ID: <475EBDB4.5020108@hp.com>
References: <475D86C1.6070400@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Mailing list NFSv4 <nfsv4@linux-nfs.org>,
	netdev ML <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Aur=E9lien_Charbon?= <aurelien.charbon@ext.bull.net>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <475D86C1.6070400@ext.bull.net>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-Id: netdev.vger.kernel.org

Hi Aurelien,

Aur=E9lien Charbon wrote:
> =

> Here is a cleanup for the ip_map caching patch in nfs server.
> =

> It prepares for IPv6 text-based mounts and exports.
> =

> Tests: tested with only IPv4 network and basic nfs ops (mount, file =

> creation and modification)

In an email back on October 29th I sent-out a similar patch with a new =

ipv6_addr_set_v4mapped() inline - it might be useful to pull that piece =

into your patch since it cleans it up a bit to get rid of the =

ipv6_addr_set() calls.  I can re-send you that patch off-line if you =

can't find it.

-Brian
