From: Grant Grundler <iod00d@hp.com>
Subject: Re: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 09:12:27 -0800
Message-ID: <20050103171227.GD7370@esmail.cup.hp.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, Andi Kleen <ak@suse.de>,
	openib-general@openib.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <openib-general-bounces@openib.org>
To: Eric Lemoine <eric.lemoine@gmail.com>
Content-Disposition: inline
In-Reply-To: <5cac192f0501030907c755135@mail.gmail.com>
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

On Mon, Jan 03, 2005 at 06:07:00PM +0100, Eric Lemoine wrote:
> If I understand correctly, LLTX aims at avoiding cache misses on lock
> variables (because of cacheline bouncing). So the effect of LLTX
> should increase as the number of CPUs not sharing the same cache
> increases. And two CPUs might not be enough...

Cacheline bouncing usually starts to show up with > 4 CPUs (ie 8 or more).
Some workloads that Jamal cares about (routing) only need 2 cpus.

grant
