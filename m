From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ath6kl: Add __printf verification to ath6kl_dbg
Date: Fri, 31 Mar 2017 10:23:59 -0700
Message-ID: <1490981039.27353.12.camel@perches.com>
References: <e4556e95a5935f591fdff67c6fb2f7ef5c7fd04f.1490914618.git.joe@perches.com>
         <CALLGbR+szcYFdbdh_0qBS4B_X6YQvU6CDFpR-XZvc7p3zA+ZdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Kalle Valo <kvalo@qca.qualcomm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Steve deRosier <derosier@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CALLGbR+szcYFdbdh_0qBS4B_X6YQvU6CDFpR-XZvc7p3zA+ZdQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-31 at 10:19 -0700, Steve deRosier wrote:
> On Thu, Mar 30, 2017 at 3:57 PM, Joe Perches <joe@perches.com> wrote:
> > Fix fallout too.
[]
> My only question is why bother doing a format check on something
> that's going to be compiled out anyway?

To avoid introducing defects when writing new code
and not using the debugging code path.
