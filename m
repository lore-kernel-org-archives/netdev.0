From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [REVIEW][PATCH 09/15] userns: Convert process event connector
 to handle kuids and kgids
Date: Sun, 26 Aug 2012 16:33:54 +0400
Message-ID: <20120826123354.GA23803@ioremap.net>
References: <87lih2h6i4.fsf@xmission.com>
 <877gsmfrkc.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	"Serge E. Hallyn" <serge@hallyn.com>,
	David Miller <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <877gsmfrkc.fsf@xmission.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 25, 2012 at 05:02:59PM -0700, Eric W. Biederman (ebiederm@xmission.com) wrote:
> 
> - Only allow asking for events from the initial user and pid namespace,
>   where we generate the events in.
> 
> - Convert kuids and kgids into the initial user namespace to report
>   them via the process event connector.


Looks good, if IDs are really supposed to be sent only from root
namespace. And you dropped PROC_EVENTS from init/Kconfig, but since it
was no, it should be ok by default.

Feel free to add my acked-by: Evgeniy Polyakov <zbr@ioremap.net>
Although I thoughs it could be more interesting to generate events
including namespace id

-- 
	Evgeniy Polyakov
