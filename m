From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Re: LLTX and netif_stop_queue
Date: Wed, 19 Jan 2005 14:47:11 -0800
Message-ID: <20050119144711.3fdd3d93.davem@davemloft.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
	<5cac192f0501030907c755135@mail.gmail.com>
	<20050103171227.GD7370@esmail.cup.hp.com>
	<1104812294.1085.53.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, eric.lemoine@gmail.com, ak@suse.de,
	openib-general@openib.org, kaber@trash.net
Return-path: <openib-general-bounces@openib.org>
To: hadi@cyberus.ca
In-Reply-To: <1104812294.1085.53.camel@jzny.localdomain>
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

On 03 Jan 2005 23:18:14 -0500
jamal <hadi@cyberus.ca> wrote:

> On Mon, 2005-01-03 at 12:12, Grant Grundler wrote:
> 
> > Some workloads that Jamal cares about (routing) only need 2 cpus.
> 
> What bothers me is more the complexity this has introduced more than
> the workload. OTOH, 1-2% improvement posted by Roland is good
> justification.

I think I'm going to put in something like Eric's patch and fix
up the other LLTX drivers as per his sungem patch.

There is a part of me that does want to yank LLTX for non-loopback
out of the tree.
