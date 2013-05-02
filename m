From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 net-next 0/6] Allow bridge to function in
 non-promisc mode
Date: Thu, 2 May 2013 14:16:26 -0700
Message-ID: <20130502141626.17fc04a7@nehalam.linuxnetplumber.net>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
	<20130502102331.43728912@nehalam.linuxnetplumber.net>
	<20130502183758.GA16031@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20130502183758.GA16031@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Thu, 2 May 2013 21:37:58 +0300
"Michael S. Tsirkin" <mst@redhat.com> wrote:

> On Thu, May 02, 2013 at 10:23:31AM -0700, Stephen Hemminger wrote:
> > Doing research on another problem, I noticed that this would
> > break user mode spanning tree (RSTP) code.
> > 
> > The daemon assumes that bridge is promicious mode and therefore
> > will receive all link-level multicast packets.
> 
> Since you have to play with the new learning/flooding
> options to get the non promisc behaviour,
> can't we just say "don't do it then"
> short term, and fix applcations long term?

It will work as long as non-promiscious mode turns on all-multicast
in driver.
