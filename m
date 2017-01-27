From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: [PATCH 6/6] wl1251: Set generated MAC address back to NVS data
Date: Fri, 27 Jan 2017 10:05:38 +0100
Message-ID: <20170127090538.GB24223@pali>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-7-git-send-email-pali.rohar@gmail.com>
 <87inp1ndgm.fsf@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87inp1ndgm.fsf@codeaurora.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 27 January 2017 09:56:09 Kalle Valo wrote:
> Pali Rohár <pali.rohar@gmail.com> writes:
> 
> > In case there is no valid MAC address kernel generates random one. This
> > patch propagate this generated MAC address back to NVS data which will be
> > uploaded to wl1251 chip. So HW would have same MAC address as linux kernel
> > uses.
> >
> > Signed-off-by: Pali Rohár <pali.rohar@gmail.com>
> 
> Why? What issue does this fix?

Send permanent MAC address to wl1251 chip, same what is doing wl12xx
driver.

-- 
Pali Rohár
pali.rohar@gmail.com
