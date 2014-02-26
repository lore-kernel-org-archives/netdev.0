From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 3/7] bridge: Add addresses from static fdbs to
 bridge address list
Date: Wed, 26 Feb 2014 08:57:07 -0800
Message-ID: <20140226085707.55bdab94@nehalam.linuxnetplumber.net>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393427905-6811-4-git-send-email-vyasevic@redhat.com>
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

On Wed, 26 Feb 2014 10:18:21 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> When a static fdb entry is created, add the mac address to the bridge
> address list.  This list is used to program the proper port's
> address list.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

I don't like this level of bookkeeping it starts to mix
layers between the bridge network interface as entity for talking to the
local host, and forwarding table entries.

Many times static entries are used as alternative to flooding in
environments which don't trust STP.

Plus, it looks like another major source of bugs.
