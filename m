From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 4/7] bridge: Automatically manage port
	promiscuous mode.
Date: Wed, 26 Feb 2014 08:58:26 -0800
Message-ID: <20140226085826.6d9567df@nehalam.linuxnetplumber.net>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
	<1393427905-6811-5-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	jhs@mojatatu.com, john.r.fastabend@intel.com, shemminger@vyatta.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393427905-6811-5-git-send-email-vyasevic@redhat.com>
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

On Wed, 26 Feb 2014 10:18:22 -0500
Vlad Yasevich <vyasevic@redhat.com> wrote:

> When there is only 1 flooding port, this port is programmed
> with all the address the bridge accumulated.  This allows
> us to place this port into non-promiscuous mode.
> At other times, all ports are set as promiscuous.  To help
> track whether the bridge set the mode or not, a new
> flag is introduced.
> 
> Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

This mixes the definition of outbound (flooding) and inbound (promiscuous).
Not sure if this is safe in all cases.
