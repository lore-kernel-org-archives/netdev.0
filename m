From: Eric Lemoine <eric.lemoine@gmail.com>
Subject: Re: LLTX and netif_stop_queue
Date: Mon, 3 Jan 2005 18:07:00 +0100
Message-ID: <5cac192f0501030907c755135@mail.gmail.com>
References: <52llbwoaej.fsf@topspin.com>
	<5cac192f0412230110628749e3@mail.gmail.com>
	<41CAF444.3000305@trash.net>
	<5cac192f04122408102129af43@mail.gmail.com>
	<1104240717.1100.66.camel@jzny.localdomain>
	<5cac192f0501021530672a908a@mail.gmail.com>
	<1104764660.1048.578.camel@jzny.localdomain>
	<52brc68q05.fsf@topspin.com>
	<5cac192f05010308414a25b548@mail.gmail.com>
	<527jmu8nbw.fsf@topspin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, hadi@cyberus.ca, Andi Kleen <ak@suse.de>,
	openib-general@openib.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <openib-general-bounces@openib.org>
To: Roland Dreier <roland@topspin.com>
In-Reply-To: <527jmu8nbw.fsf@topspin.com>
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

On Mon, 03 Jan 2005 08:54:59 -0800, Roland Dreier <roland@topspin.com> wrote:
>     Eric> What are your machines? In particular, how many CPUs do they have?
> 
> Dual Xeons with HT on, so they look like 4 CPUs.

If I understand correctly, LLTX aims at avoiding cache misses on lock
variables (because of cacheline bouncing). So the effect of LLTX
should increase as the number of CPUs not sharing the same cache
increases. And two CPUs might not be enough...

-- 
Eric
