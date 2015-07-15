From: Emmanuel Grumbach <egrumbach@gmail.com>
Subject: Re: [PATCH] iwlwifi: Deinline iwl_{read,write}{8,32}
Date: Wed, 15 Jul 2015 20:49:59 +0300
Message-ID: <CANUX_P2=J81pJpyeMLEf+un=Pe8MhoGz7QJrrRUe19oeux8BhQ@mail.gmail.com>
References: <1436876558-6674-1-git-send-email-dvlasenk@redhat.com>
	<55A502B6.5090806@cogentembedded.com>
	<CAK1hOcPvb3mOeVm5HMqSCKAyJv47HturM+C9uxvA1=KWn94dtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Denys Vlasenko <dvlasenk@redhat.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Johannes Berg <johannes.berg@intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAK1hOcPvb3mOeVm5HMqSCKAyJv47HturM+C9uxvA1=KWn94dtw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 14, 2015 at 3:41 PM, Denys Vlasenko
<vda.linux@googlemail.com> wrote:
> On Tue, Jul 14, 2015 at 2:38 PM, Sergei Shtylyov
> <sergei.shtylyov@cogentembedded.com> wrote:
>>> +#define IWL_READ_WRITE(static_inline) \
>>> +static_inline void iwl_write8(struct iwl_trans *trans, u32 ofs, u8 val) \
>>> +{ \
>>> +       trace_iwlwifi_dev_iowrite8(trans->dev, ofs, val); \
>>> +       iwl_trans_write8(trans, ofs, val); \
>>> +} \
>> [...]
>>>
>>> +#if !defined(CONFIG_IWLWIFI_DEVICE_TRACING)
>>> +IWL_READ_WRITE(static inline)
>>
>>    Not static_inline?
>
> Yes. Here we are putting two words, "static inline", in front of every
> function definition.
> --

I'll try to come up with a patch that is easier for me to read, but I
am really busy right now. Ping me in a week if you have heard from me
earlier.
