From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH linux 2/2] fs/proc: use a hash table for the directory
 entries
Date: Fri, 03 Oct 2014 15:07:01 +0200
Message-ID: <542E9F75.6070407@6wind.com>
References: <20131003.150947.2179820478039260398.davem@davemloft.net> <1412263501-6572-1-git-send-email-nicolas.dichtel@6wind.com> <1412263501-6572-3-git-send-email-nicolas.dichtel@6wind.com> <20141002172814.GA2435@p183.telecom.by>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, ebiederm@xmission.com,
	akpm@linux-foundation.org, rui.xiang@huawei.com,
	viro@zeniv.linux.org.uk, oleg@redhat.com, gorcunov@openvz.org,
	kirill.shutemov@linux.intel.com, grant.likely@secretlab.ca,
	tytso@mit.edu, Thierry Herbelot <thierry.herbelot@6wind.com>
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141002172814.GA2435@p183.telecom.by>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 02/10/2014 19:28, Alexey Dobriyan a =E9crit :
> On Thu, Oct 02, 2014 at 05:25:01PM +0200, Nicolas Dichtel wrote:
>> +static inline unsigned int proc_pde_name_hash(const unsigned char *=
name,
>> +					      const unsigned int len)
>> +{
>> +	return full_name_hash(name, len) & PROC_PDE_HASH_MASK;
>> +}
>
> PDE already stands for "proc dir entry" :^)
>
> 	Alexey
>
Oops, will fix it in v2.


Thank you,
Nicolas
