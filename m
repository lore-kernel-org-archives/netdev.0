From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [RFC PATCH 5/7] Multiple VF's grouped together under single
 physical port called PF group PF Group maintainance API's
Date: Wed, 21 Dec 2016 18:13:45 +0530
Message-ID: <CA+sq2Cf=3-WUaT+iNefYswgGf2ejW6EQp1igcMWELU=-xUnnNA@mail.gmail.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com> <1482310011-1862-6-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: LKML <linux-kernel@vger.kernel.org>,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        David Daney <david.daney@cavium.com>,
        rvatsavayi@caviumnetworks.com, derek.chickles@caviumnetworks.com,
        philip.romanov@cavium.com,
        Linux Netdev List <netdev@vger.kernel.org>,
        LAKML <linux-arm-kernel@lists.infradead.org>
To: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1482310011-1862-6-git-send-email-satha.rao@caviumnetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 21, 2016 at 2:16 PM, Satha Koteswara Rao
<satha.rao@caviumnetworks.com> wrote:
> +struct tns_global_st {
> +       u64 magic;
> +       char     version[16];
> +       u64 reg_cnt;
> +       struct table_static_s tbl_info[TNS_MAX_TABLE];
> +};
> +
> +#define PF_COUNT 3
> +#define PF_1   0
> +#define PF_2   64
> +#define PF_3   96
> +#define PF_END 128

Some comments please ... what is 0, 64, 96 ??
You can read PCI_SRIOV_TOTAL_VF from PCI config space instead of
defining PF_END with 128.
