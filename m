From: Arturo Borrero Gonzalez <arturo.borrero.glez@gmail.com>
Subject: Re: mmotm 2014-09-25-16-28 uploaded (nf_nat_masquerade_ipv4.c)
Date: Fri, 26 Sep 2014 19:03:44 +0200
Message-ID: <CAOkSjBhqhNYO3S1Gc1A4oOeONAriMbDQ=aStgB6EtZK=W+gNgA@mail.gmail.com>
References: <5424a53b.o+nym6SX0Tg7EdW6%akpm@linux-foundation.org> <54259A5C.2060102@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org,
	Netfilter Development Mailing list
	<netfilter-devel@vger.kernel.org>, linux-next@vger.kernel.org,
	sfr@canb.auug.org.au, mhocko@suse.cz
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54259A5C.2060102@infradead.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 26 September 2014 18:54, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 09/25/14 16:28, akpm@linux-foundation.org wrote:
>> The mm-of-the-moment snapshot 2014-09-25-16-28 has been uploaded to
>>
>>    http://www.ozlabs.org/~akpm/mmotm/
>>
>> mmotm-readme.txt says
>>
>> README for mm-of-the-moment:
>>
>> http://www.ozlabs.org/~akpm/mmotm/
>>
>> This is a snapshot of my -mm patch queue.  Uploaded at random hopefu=
lly
>> more than once a week.
>
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c: In function 'nf_nat_m=
asquerade_ipv4':
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:59:5: error: 'struct n=
f_conn_nat' has no member named 'masq_index'
>   nat->masq_index =3D out->ifindex;
>      ^
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c: In function 'device_c=
mp':
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:83:12: error: 'const s=
truct nf_conn_nat' has no member named 'masq_index'
>   return nat->masq_index =3D=3D (int)(long)ifindex;
>             ^
> ../net/ipv4/netfilter/nf_nat_masquerade_ipv4.c:84:1: warning: control=
 reaches end of non-void function [-Wreturn-type]
>
>

That seems fixed in this commit by Pablo Neira:

http://git.kernel.org/cgit/linux/kernel/git/pablo/nf-next.git/commit/?i=
d=3D67981fefb20e717cea55b42f9081a833fa46b3be

I guess the patch will hit linux-next soon.

Thanks, regards.

--=20
Arturo Borrero Gonz=C3=A1lez
