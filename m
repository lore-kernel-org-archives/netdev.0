From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] net: make ctl_path local and const
Date: Wed, 20 Oct 2010 11:10:36 +0800
Message-ID: <AANLkTi=pz4zYnnUSvb9FjVvCAURruHhJTz7pBKDi8Pdw@mail.gmail.com>
References: <1287543276-4511-1-git-send-email-xiaosuo@gmail.com>
	<1287543701.10409.599.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Andy Grover <andy.grover@oracle.com>, linux-sctp@vger.kernel.org,
        rds-devel@oss.oracle.com, "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
        linux-x25@vger.kernel.org, dccp@vger.kernel.org,
        bridge@lists.linux-foundation.org, James Morris <jmorris@namei.org>,
        coreteam@netfilter.org,
        Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Joerg Reuter <jreuter@yaina.de>, Sridhar Samudrala <sri@us.ibm.com>,
        Samuel Ortiz <samuel@sortiz.org>,
        Vlad Yasevich <vladislav.yasevich@hp.com>, netfilter@vger.kernel.org,
        Remi Denis-Courmont <remi.denis-courmont@nokia.com>,
        linux-hams@vger.kernel.org,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
        linux-decnet-user@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        Ralf Baechle <ralf
To: Joe Perches <joe@perches.com>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <1287543701.10409.599.camel@Joe-Laptop>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 20, 2010 at 11:01 AM, Joe Perches <joe@perches.com> wrote:
> On Wed, 2010-10-20 at 10:54 +0800, Changli Gao wrote:
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> []
>> diff --git a/net/appletalk/sysctl_net_atalk.c b/net/appletalk/sysctl_net=
_atalk.c
>> index 04e9c0d..b92f269 100644
>> --- a/net/appletalk/sysctl_net_atalk.c
>> +++ b/net/appletalk/sysctl_net_atalk.c
>> @@ -42,16 +42,16 @@ static struct ctl_table atalk_table[] =3D {
>> =A0 =A0 =A0 { },
>> =A0};
>>
>> -static struct ctl_path atalk_path[] =3D {
>> - =A0 =A0 { .procname =3D "net", },
>> - =A0 =A0 { .procname =3D "appletalk", },
>> - =A0 =A0 { }
>> -};
>> -
>> =A0static struct ctl_table_header *atalk_table_header;
>>
>> =A0void atalk_register_sysctl(void)
>> =A0{
>> + =A0 =A0 const struct ctl_path atalk_path[] =3D {
>
> Shouldn't all of these be static const struct ?
>
>

They needn't. And some variables are specified __net_initdata currently.

-- =

Regards,
Changli Gao(xiaosuo@gmail.com)
