From: Bjorn Andersson <bjorn.andersson@linaro.org>
Subject: Re: [PATCH v4 2/4] wcn36xx: Transition driver to SMD client
Date: Thu, 8 Sep 2016 21:21:59 -0700
Message-ID: <20160909042159.GD405@tuxbot>
References: <1473200312-22438-1-git-send-email-bjorn.andersson@linaro.org>
 <1473200312-22438-2-git-send-email-bjorn.andersson@linaro.org>
 <87k2emsi22.fsf@kamboji.qca.qualcomm.com>
 <CAOCOHw5Wvy5g0HuDaYUZ2WTCws5uXtw6DO7S3Dvp+0mgW-Mg=Q@mail.gmail.com>
 <878tv2s3ao.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eugene Krasnikov <k.eugene.e@gmail.com>,
        wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
        netdev <netdev@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>,
        Andy Gross <andy.gross@linaro.org>,
        linux-arm-msm <linux-arm-msm@vger.kernel.org>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <878tv2s3ao.fsf@kamboji.qca.qualcomm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu 08 Sep 10:35 PDT 2016, Kalle Valo wrote:

> Bjorn Andersson <bjorn.andersson@linaro.org> writes:
> 
> > On Thu, Sep 8, 2016 at 5:16 AM, Kalle Valo <kvalo@codeaurora.org> wrote:
> >> Bjorn Andersson <bjorn.andersson@linaro.org> writes:
> >>
> >>> The wcn36xx wifi driver follows the life cycle of the WLAN_CTRL SMD
> >>> channel, as such it should be a SMD client. This patch makes this
> >>> transition, now that we have the necessary frameworks available.
> >>>
> >>> Signed-off-by: Bjorn Andersson <bjorn.andersson@linaro.org>
> >>> ---
> >>>
> >>> Changes since v3:
> >>> - Made msg_header const in wcn36xx_smd_rsp_process()
> >>>
> >>> Changes since v2:
> >>> - Correct the call to the new ieee80211_scan_completed()
> >>>
> >>>  drivers/net/wireless/ath/wcn36xx/dxe.c     | 16 +++---
> >>>  drivers/net/wireless/ath/wcn36xx/main.c    | 79 ++++++++++++++++++++----------
> >>>  drivers/net/wireless/ath/wcn36xx/smd.c     | 31 +++++-------
> >>>  drivers/net/wireless/ath/wcn36xx/smd.h     |  5 ++
> >>>  drivers/net/wireless/ath/wcn36xx/wcn36xx.h | 21 +++-----
> >>>  5 files changed, 86 insertions(+), 66 deletions(-)
> >>
> >> This doesn't compile for me:
> >>
> >
> > I thought I mentioned this in the mail, sorry for missing that.
> 
> Maybe you did and I just forgot, I have a tendency to do that :)
> 
> > There is a patch for this issue in linux-next already [1] which is
> > part of [2], which was part of the pull request to arm-soc for
> > inclusion in v4.9.
> >
> > [1] https://patchwork.kernel.org/patch/9272457/
> > [2] https://git.kernel.org/cgit/linux/kernel/git/agross/linux.git/tag/?h=qcom-drivers-for-4.9
> 
> So the commit in question is:
> 
> soc: qcom: smd: Correct compile stub prototypes
> https://git.kernel.org/cgit/linux/kernel/git/agross/linux.git/commit/?h=qcom-drivers-for-4.9&id=3a1281848830fcb3202cfd7ffe62d19641471d05
> 

Correct

> But that's not obviously in my tree yet, but I should have it after
> 4.9-rc1 is released. I think it's easiest that I wait for that before
> applying these. Do you agree?
> 

Would be nice to have it land sooner rather than later, but I'm okay
with this.

Regards,
Bjorn
