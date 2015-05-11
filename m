From: Jonas Gorski <jogo@openwrt.org>
Subject: Re: [PATCH 2/2] adm8211: fix the possible pci cache line sizes inside switch-case
Date: Mon, 11 May 2015 15:24:18 +0200
Message-ID: <CAOiHx=kzSsFenqPSNeAX6P5wJK8Hr-q+s+rJoQQMPbSGmE50xw@mail.gmail.com>
References: <20150505224020.GA3805@bytefire-computer> <87wq0ms3mv.fsf@kamboji.qca.qualcomm.com>
 <20150506063241.GA3042@bytefire-computer> <87k2wflj7p.fsf@kamboji.qca.qualcomm.com>
 <2CBE2DDF-92E5-45C9-95F8-C5CF918D12D9@gmail.com> <87vbfzjt4t.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Okash Khawaja <okash.khawaja@gmail.com>,
	"joe@perches.com" <joe@perches.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87vbfzjt4t.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Mon, May 11, 2015 at 12:38 PM, Kalle Valo <kvalo@codeaurora.org> wrote:
> Okash Khawaja <okash.khawaja@gmail.com> writes:
>
>> Sure, I'll create v2 of the patch with updated commit log.
>>
>> Since it's part of a patch set, do you want me to send both the
>> patches in the patch set together as v2 or just this patch?
>
> Please resend the whole patchset as v2, less problems that way.

If you are sending a v2 anyway, I'd suggest using decimal values for
the cases, as cache line sizes are usually given in decimal anyway. So
just drop the "0x" instead of converting the values ;-)


Jonas
