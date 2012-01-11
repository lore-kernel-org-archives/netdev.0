From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
Date: Wed, 11 Jan 2012 22:03:17 +0400
Message-ID: <4F0DCEE5.5090100@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>			 <1325285705.10984.4.camel@lade.trondhjem.org>		 <1325797111.11084.22.camel@lade.trondhjem.org>		 <4F0C35F3.7060508@parallels.com>	 <1326299003.17212.7.camel@lade.trondhjem.org>	 <4F0DC582.6030805@parallels.com> <1326303963.19024.1.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Pavel Emelianov <xemul@parallels.com>,
	"neilb@suse.de" <neilb@suse.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	James Bottomley <jbottomley@parallels.com>,
	"bfields@fieldses.org" <bfields@fieldses.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"devel@openvz.org" <devel@openvz.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1326303963.19024.1.camel@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

11.01.2012 21:46, Trond Myklebust =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, 2012-01-11 at 21:23 +0400, Stanislav Kinsbursky wrote:
>> I've sent rebased "v2" of the patch set, contains updated patch "SUN=
RPC: handle
>> RPC client pipefs dentries by network namespace aware routine", whic=
h, I
>> believe, fixes oops, spotted by Bryan (it was caused by excessive ca=
ll of
>> rpc_put_mount() on PipeFS dentries unlink).
>> So, if I'm not mistaken here, there's no need in implementing of dum=
my versions
>> of rpc_pipefs_notifier_(un)register() or any other dummy stuff.
>
> OK. Fair enough. We'll give it some testing to make sure that we don'=
t
> hit it again...
>
>> BTW, it looks like that in last 2 days I've sent all updates to the =
issues you
>> pointed out. If not, please, ping me once more.
>
> I'm in the process of reviewing it right now.
>

Cool, thanks, Trond.

> Cheers
>    Trond
>


--=20
Best regards,
Stanislav Kinsbursky
