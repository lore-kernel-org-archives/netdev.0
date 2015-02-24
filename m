From: Josh Hunt <johunt@akamai.com>
Subject: Re: [PATCH v3 0/2] nft hash resize fixes
Date: Tue, 24 Feb 2015 11:42:35 -0600
Message-ID: <54ECB80B.3040800@akamai.com>
References: <1424798736-11857-1-git-send-email-johunt@akamai.com> <54ECB661.9050306@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: nicolas.dichtel@6wind.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <54ECB661.9050306@6wind.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/24/2015 11:35 AM, Nicolas Dichtel wrote:
> Le 24/02/2015 18:25, Josh Hunt a =C3=A9crit :
>> v3:
>>   * Renames NFT_HASH_MAX_ELEMENTS to NFT_HASH_MAX_BUCKETS
>>   * Add Acked-by for Thomas
>>
>> Josh Hunt (2):
>>    rhashtable: require max_shift if grow_decision defined
>>    nft_hash: define max_shift rhashtable parameter
> Patches should be inverted to avoid breaking bisection.

Agreed. Will fix in next rev.

Josh
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
