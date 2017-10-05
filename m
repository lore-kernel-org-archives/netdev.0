From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] net: qcom/emac: make function emac_isr static
Date: Thu, 5 Oct 2017 14:31:58 -0500
Message-ID: <d47cb43f-a4d7-8e54-93da-1db2ce213096@codeaurora.org>
References: <20171005091023.27781-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171005091023.27781-1-colin.king@canonical.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/05/2017 04:10 AM, Colin King wrote:
> From: Colin Ian King<colin.king@canonical.com>
> 
> The function emac_isr is local to the source and does not need to
> be in global scope, so make it static.
> 
> Cleans up sparse warnings:
> symbol 'emac_isr' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King<colin.king@canonical.com>

ACK

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
