From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: Re: [PATCH net-next 3/7] net: Move check for multiple
	vlans to drivers
Date: Fri, 27 Mar 2015 14:28:54 +0900
Message-ID: <5514EA96.5090908@lab.ntt.co.jp>
References: <1427346080-12086-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	
	<1427346080-12086-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<1427370936.25985.133.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>, Jiri Pirko <jiri@resnulli.us>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	e1000-devel@lists.sourceforge.net, Jay Vosburgh <j.vosburgh@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Veaceslav Falico <vfalico@gmail.com>, Ariel Elior <ariel.elior@qlogic.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Linux NICS <linux.nics@intel.com>, Dept-GELinuxNICDev@qlogic.com,
	"David S . Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1427370936.25985.133.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On 2015/03/26 20:55, Eric Dumazet wrote:
...
>> +/**
>> + * vlan_features_check - drop unsafe features for skb with multiple tags.
>> + * @skb: skbuff to query
>> + * @features: features to be checked
>> + *
>> + * Returns features without unsafe ones if the skb has multiple tags.
>> + */
>> +static inline netdev_features_t vlan_features_check(struct sk_buff *skb,
> 
> const struct sk_buff *skb
> 
>> +						    netdev_features_t features)
>> +{
>> +	if (skb_vlan_tagged_multi(skb))
...
>> @@ -2562,6 +2562,13 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
>>  	return features;
>>  }
>>  
>> +static netdev_features_t dflt_features_check(struct sk_buff *skb,
> 
> const struct sk_buff *skb

Thank you, I fixed them and your another feedback for patch 2.
will send v2.

Toshiaki Makita


------------------------------------------------------------------------------
Dive into the World of Parallel Programming The Go Parallel Website, sponsored
by Intel and developed in partnership with Slashdot Media, is your hub for all
things parallel software development, from weekly thought leadership blogs to
news, videos, case studies, tutorials and more. Take a look and join the 
conversation now. http://goparallel.sourceforge.net/
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
