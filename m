From: Michael Chan <michael.chan@broadcom.com>
Subject: Re: [PATCH net-next 1/2] bnxt_en: don't consider building bnxt_tc.o
 if option not enabled
Date: Fri, 6 Oct 2017 18:01:57 -0700
Message-ID: <CACKFLikAM3sfHYA-VnNbHWN_aYaG92MwpHjhN3dzhyONDaoTuw@mail.gmail.com>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>,
        open list <linux-kernel@vger.kernel.org>
To: Jonathan Toppins <jtoppins@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 6, 2017 at 12:48 PM, Jonathan Toppins <jtoppins@redhat.com> wrote:
> Instead of zeroing out bnxt_tc.c with a #ifdef foo, instead don't compile
> the file when the option is not enabled. Now make and the preprocessor do
> not have to waste time compiling a no-op.
>
> Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>

Acked-by: Michael Chan <michael.chan@broadcom.com>
