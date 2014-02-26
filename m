From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH RFC 0/7] Non-promisc bidge ports support
Date: Wed, 26 Feb 2014 18:59:29 -0500
Message-ID: <530E7FE1.5060705@mojatatu.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, shemminger@vyatta.com,
	bridge@lists.linux-foundation.org, mst@redhat.com
To: Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
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

On 02/26/14 10:18, Vlad Yasevich wrote:
> This patch series is a complete re-design and re-implementation of
> prior attempts to support non-promiscuous bridge ports.
>
> The basic design is as follows.  The bridge keeps track of
> all the ports that flood packets to unknown destinations.  If
> the flooding is disabled on the port, to get traffic to flow
> through, user/management would need to add an fdb describing
> such traffic.  When such fdb is added, we save the address
> to bridge private hardware address list.

Entering the addresses in the uc list on other bridgeports seems
reasonable for the scenario described.
But would it _also_ need to be added to the fdb of the bridge?
i.e how does the bridge (if the packet was to be handed to it)
know where to forward?
BTW: on the comment that flooding off implies learning off: I would like
to be able to turn off flooding on a specific bridge port but
still want to learn from it. I dont think those two are mutually
exclusive.

cheers,
jamal
