From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] ath6kl: Use vmalloc to allocate ar->fw for api1 method
Date: Tue, 1 Dec 2015 16:08:29 +0300
Message-ID: <565D9BCD.6020105@cogentembedded.com>
References: <1448948470-31111-1-git-send-email-motobud@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ath6kl@lists.infradead.org
To: Brent Taylor <motobud@gmail.com>, kvalo@qca.qualcomm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448948470-31111-1-git-send-email-motobud@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 12/1/2015 8:41 AM, Brent Taylor wrote:

> Since commit 8437754c83351d6213c1a47ff029c1126d6042a7,

    The scripts/checkpatch.pl now enforces certain format of the commit citing.

> ar->fw is expected to be pointing to memory allocated by vmalloc.  If the api1 method (via ath6kl_fetch_fw_api1) is used to allocate memory for ar->fw, then kmemdup is used.  This patch checks if the firmware being loaded is the 'fw' image, then use vmalloc, otherwise use kmalloc.

    This script also checks for unwrapped changelogs. Please run your patches 
thru it before posting.

> Signed-off-by: Brent Taylor <motobud@gmail.com>
[...]

MBR, Sergei
