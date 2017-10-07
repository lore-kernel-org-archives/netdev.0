From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/3] bridge: neigh msg proxy and
 flood suppression support
Date: Sat, 07 Oct 2017 06:46:56 +0100 (WEST)
Message-ID: <20171007.064656.350053402823144762.davem@davemloft.net>
References: <1507314880-16310-1-git-send-email-roopa@cumulusnetworks.com>
	<CAJieiUhec_RU3ncjYd-PjUkduvmprwXmj-9S7Uy1LKSD4dzbAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nikolay@cumulusnetworks.com, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: roopa@cumulusnetworks.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <CAJieiUhec_RU3ncjYd-PjUkduvmprwXmj-9S7Uy1LKSD4dzbAg@mail.gmail.com>
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

From: Roopa Prabhu <roopa@cumulusnetworks.com>
Date: Fri, 6 Oct 2017 19:35:27 -0700

> On Fri, Oct 6, 2017 at 11:34 AM, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> This series implements arp and nd suppression in the bridge
>> driver for ethernet vpns. It implements rfc7432, section 10
>> https://tools.ietf.org/html/rfc7432#section-10
>> for ethernet VPN deployments. It is similar to the existing
>> BR_PROXYARP* flags but has a few semantic differences to conform
>> to EVPN standard. Unlike the existing flags, this new flag suppresses
>> flood of all neigh discovery packets (arp and nd) to tunnel ports.
>> Supports both vlan filtering and non-vlan filtering bridges.
>>
>> In case of EVPN, it is mainly used to avoid flooding
>> of arp and nd packets to tunnel ports like vxlan.
>>
>> v2 : rebase to latest + address some optimization feedback from Nikolay.
>> v3 : fix kbuild reported build errors with CONFIG_INET off
>> v4 : simplify port flag mask as suggested by stephen
>> v5 : address some feedback from Toshiaki
>>
> 
> Looks like I missed applying a cleanup done in v5 to the ipv6 nd path.
> Dave, I see these patches 'under review' in patchworks. If its not too
> late, pls drop them. I will spin v6 in a few hrs. thanks.

Ok.
