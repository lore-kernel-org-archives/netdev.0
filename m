From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH v2 net 0/3] bridge: Add vlan filtering support
 for default pvid
Date: Tue, 30 Sep 2014 19:16:19 -0400
Message-ID: <542B39C3.1070808@redhat.com>
References: <1412105462-340-1-git-send-email-vyasevic@redhat.com>
	<20140930.170718.1417042696038383945.davem@davemloft.net>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>, vyasevich@gmail.com
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20140930.170718.1417042696038383945.davem@davemloft.net>
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

On 09/30/2014 05:07 PM, David Miller wrote:
> From: Vladislav Yasevich <vyasevich@gmail.com>
> Date: Tue, 30 Sep 2014 15:30:59 -0400
> 
>> Version 2 of the series to introduce the default pvid support to
>> vlan filtering in the bridge.  VLAN 1 (as recommended by 802.1q spec)
>> is used as default pvid on ports. 
>> The the user can over-ride this configuration by configuring their
>> own vlan information. 
>> The user can additionally change the default value throught the
>> sysfs interface (netlink comming shortly).
>> The user can turn off default pvid functionality by setting default
>> pvid to 0. 
>> This series changes the default behavior of the bridge when
>> vlan filtering is turned on.  Currently, ports without any vlan
>> filtering configured will not recevie any traffic at all.  This patch
>> changes the behavior of the above ports to receive only untagged traffic.
>>
>> Since v2:
>> - Add ability to turn off default_pvid settings.
>> - Drop the automiatic filtering support based on configured vlan devices (will
>>   be its own series)
> 
> Looks like a new feature to me, thus why is this being targetted at 'net'
> instead of 'net-next'?
> 

goof on my part.  This should be net-next.

-vlad
