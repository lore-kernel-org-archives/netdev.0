From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Mar 9 (net: bpf)
Date: Wed, 9 Mar 2016 09:18:02 -0800
Message-ID: <56E05ACA.40602@infradead.org>
References: <20160309163852.4dd159b1@canb.auug.org.au>
 <56E052E4.90504@infradead.org> <56E053D3.7090009@iogearbox.net>
 <56E0583A.1080205@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E0583A.1080205@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/09/16 09:07, Randy Dunlap wrote:
> On 03/09/16 08:48, Daniel Borkmann wrote:
>> On 03/09/2016 05:44 PM, Randy Dunlap wrote:
>>> On 03/08/16 21:38, Stephen Rothwell wrote:
>>>> Hi all,
>>>>
>>>> Changes since 20160308:
>>>
>>> on x86_64:
>>>
>>> ../net/core/filter.c: In function 'bpf_skb_get_tunnel_opt':
>>> ../net/core/filter.c:1824:2: error: implicit declaration of function 'ip_tunnel_info_opts_get' [-Werror=implicit-function-declaration]
>>>    ip_tunnel_info_opts_get(to, info);
>>>    ^
>>> ../net/core/filter.c: In function 'bpf_skb_set_tunnel_opt':
>>> ../net/core/filter.c:1918:2: error: implicit declaration of function 'ip_tunnel_info_opts_set' [-Werror=implicit-function-declaration]
>>>    ip_tunnel_info_opts_set(info, from, size);
>>>    ^
>>> Full randconfig file is attached.
>>
>> Already fixed with net-next commit e28e87ed474c ("ip_tunnel, bpf:
>> ip_tunnel_info_opts_{get, set} depends on CONFIG_INET").
>>
>> Thanks,
>> Daniel
>>
> 
> Hi Daniel,
> 
> Is that patch on the netdev mailing list or patchwork?
> I can't find it.
> 
> Does it handle where net/Kconfig symbol NET selects BPF unconditionally?

I got the patch from git and tested it.  Works.  Thanks.



-- 
~Randy
