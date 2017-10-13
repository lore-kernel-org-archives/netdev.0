From: Daniel Drake <drake@endlessm.com>
Subject: Re: [PATCH 2/6] ath9k: add a quirk to set use_msi automatically
Date: Fri, 13 Oct 2017 09:17:04 +0800
Message-ID: <CAD8Lp46ZHN656P_aROGs5WyxNckga7rBUrcDJpEApwtRvA0yhg@mail.gmail.com>
References: <1506408099-18488-1-git-send-email-acelan.kao@canonical.com>
 <1506408099-18488-2-git-send-email-acelan.kao@canonical.com>
 <20170926064456.GA28611@infradead.org> <CAFv23Qm9kZLSqJ_BP1D7mWCxekq0nt3S8onT1ckH-AoHDBUDzw@mail.gmail.com>
 <20170926140413.GA19977@infradead.org> <878th14kde.fsf@kamboji.qca.qualcomm.com>
 <CAFv23Qn4OMuHaSA6UG+Q7L1sTt+ZO8T-JYVaBM1FxZtGNxOhdQ@mail.gmail.com>
 <CAD8Lp46mdgbfCGY_i=N7FB1rMfL0KA0VFQxJESxshe4Cn6k4+Q@mail.gmail.com>
 <CAFv23QkLJ0m112Y8iAGv+6DyFT52Hqnxq5Fy=ryWTWxu8oTXdw@mail.gmail.com> <CAFv23Q=dFRfxXQnY3pu_zV-yK9yaw-t3-Kn2q9YFFuyB9jJMog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kalle Valo <kvalo@codeaurora.org>,
        Christoph Hellwig <hch@infradead.org>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        "Linux-Kernel@Vger. Kernel. Org" <linux-kernel@vger.kernel.org>
To: AceLan Kao <acelan.kao@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAFv23Q=dFRfxXQnY3pu_zV-yK9yaw-t3-Kn2q9YFFuyB9jJMog@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 13, 2017 at 9:12 AM, AceLan Kao <acelan.kao@canonical.com> wrote:
> Hi Daniel,
>
> After applied the 2 commits you mentioned in the email, ath9k works.
>
> https://marc.info/?l=linux-wireless&m=150631274108016&w=2
> https://github.com/endlessm/linux/commit/739c7a924db8f4434a9617657

Thanks for testing. However the approach was basically rejected in this thread:
  [PATCH] PCI MSI: allow alignment restrictions on vector allocation
  https://marc.info/?t=150631283200001&r=1&w=2

So we still need an upstream solution.

I am curious what Qualcomm have to say about their hardware corrupting
the MSI Message Data value. Is there any news on them submitting the
MSI support patch?

Separately we have the option of seeing if Intel can help us unblock
the legacy interrupt (assuming it was simply blocked by the BIOS), or
adding an interrupt-polling fallback path to ath9k.

Daniel
