From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/15] add Documentation/namespaces/user_namespace.txt
 (v3)
Date: Wed, 7 Sep 2011 15:50:24 -0700
Message-ID: <20110907155024.42e3fe27.akpm@linux-foundation.org>
References: <1314993400-6910-1-git-send-email-serge@hallyn.com>
	<1314993400-6910-4-git-send-email-serge@hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: segooon@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	dhowells@redhat.com, ebiederm@xmission.com, rdunlap@xenotime.net,
	"Serge E. Hallyn" <serge.hallyn@canonical.com>
To: Serge Hallyn <serge@hallyn.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1314993400-6910-4-git-send-email-serge@hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri,  2 Sep 2011 19:56:26 +0000
Serge Hallyn <serge@hallyn.com> wrote:

> +Note that this userid mapping for the VFS is not yet implemented, though the
> +lkml and containers mailing list archives will show several previous
> +prototypes.  In the end, those got hung up waiting on the concept of targeted
> +capabilities to be developed, which, thanks to the insight of Eric Biederman,
> +they finally did.

not-yet-implemented things worry me.  When can we expect this to
happen, and how big and ugly will it be?

I'm not seeing many (any) reviewed-by's on these patches.  I could get
down and stare at them myself, but that wouldn't be very useful.  This
work goes pretty deep and is quite security-affecting.  And network-afecting.
Can you round up some suitable people and get the reviewing and testing happening
please?
