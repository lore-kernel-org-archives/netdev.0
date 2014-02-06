From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] inet: defines IPPROTO_* needed for module alias generation
Date: Thu, 6 Feb 2014 13:51:16 -0800
Message-ID: <CAHA+R7NFRKU_XDpJT1ZFdx0Rp67qpnwcHw5asAxT_oG8wQTM6A@mail.gmail.com>
References: <1391685000-7346-1-git-send-email-mq@suse.cz>
	<52F3FFBC.1010505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jan Moskyto Matejka <mq@suse.cz>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "Carlos O'Donell" <carlos@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52F3FFBC.1010505@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 6, 2014 at 1:33 PM, Carlos O'Donell <carlos@redhat.com> wrote:
> On 02/06/2014 06:10 AM, Jan Moskyto Matejka wrote:
>> Reverting this change back to define's to fix the aliases.
>>
>> modinfo mip6 (before this change)
>> alias:          xfrm-type-10-IPPROTO_DSTOPTS
>> alias:          xfrm-type-10-IPPROTO_ROUTING
>>
>> modinfo mip6 (after this change)
>> alias:          xfrm-type-10-43
>> alias:          xfrm-type-10-60
>
> Instead of reverting these changes I suggest someone fix
> whatever is processing that information.

It is stringfy by c preprocessor. enum should be processed
after preprocessing, therefore fails to be converted to it
real value at preprocessing stage.
