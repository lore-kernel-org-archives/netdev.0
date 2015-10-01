From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCHv2 7/7] openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT
Date: Thu, 1 Oct 2015 15:26:10 -0700
Message-ID: <CALnjE+oJubEG33D4+gmAkGjm7t_UucJdPuX1JTC33Ba-NeDtcg@mail.gmail.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
	<1443732810-38746-8-git-send-email-joestringer@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Jesse Gross <jesse@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443732810-38746-8-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 1, 2015 at 1:53 PM, Joe Stringer <joestringer@nicira.com> wrote:
> Previously, the CT_ATTR_FLAGS attribute, when nested under the
> OVS_ACTION_ATTR_CT, encoded a 32-bit bitmask of flags that modify the
> semantics of the ct action. It's more extensible to just represent each
> flag as a nested attribute, and this requires no additional error
> checking to reject flags that aren't currently supported.
>
> Suggested-by: Ben Pfaff <blp@nicira.com>
> Signed-off-by: Joe Stringer <joestringer@nicira.com>
> ---
> v2: Use bitmask for internal representation of COMMIT.
> ---
Acked-by: Pravin B Shelar <pshelar@nicira.com>
