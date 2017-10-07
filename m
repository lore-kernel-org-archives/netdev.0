From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bnxt_en: don't consider building
 bnxt_tc.o if option not enabled
Date: Sat, 07 Oct 2017 03:00:35 +0100 (WEST)
Message-ID: <20171007.030035.899474172732259314.davem@davemloft.net>
References: <1a4d96f368f199bba0425012f50d55d634484cce.1507319311.git.jtoppins@redhat.com>
        <CACKFLikAM3sfHYA-VnNbHWN_aYaG92MwpHjhN3dzhyONDaoTuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jtoppins@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CACKFLikAM3sfHYA-VnNbHWN_aYaG92MwpHjhN3dzhyONDaoTuw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Chan <michael.chan@broadcom.com>
Date: Fri, 6 Oct 2017 18:01:57 -0700

> On Fri, Oct 6, 2017 at 12:48 PM, Jonathan Toppins <jtoppins@redhat.com> wrote:
>> Instead of zeroing out bnxt_tc.c with a #ifdef foo, instead don't compile
>> the file when the option is not enabled. Now make and the preprocessor do
>> not have to waste time compiling a no-op.
>>
>> Signed-off-by: Jonathan Toppins <jtoppins@redhat.com>
> 
> Acked-by: Michael Chan <michael.chan@broadcom.com>

Applied.
