From: Colin Ian King <colin.king@canonical.com>
Subject: Re: [PATCH] ethernet: aquantia: remove redundant checks on error
 status
Date: Thu, 11 May 2017 19:18:08 +0100
Message-ID: <174d4afe-16a8-cd2d-9be9-0f502cc89a59@canonical.com>
References: <20170511172929.12951-1-colin.king@canonical.com>
 <20170511.141623.1200573443845531222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: pavel.belous@aquantia.com, Dmitrii.Tarakanov@aquantia.com,
        Alexander.Loktionov@aquantia.com, vomlehn@texas.net,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170511.141623.1200573443845531222.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/05/17 19:16, David Miller wrote:
> From: Colin King <colin.king@canonical.com>
> Date: Thu, 11 May 2017 18:29:29 +0100
> 
>> From: Colin Ian King <colin.king@canonical.com>
>>
>> The error status err is initialized as zero and then being checked
>> several times to see if it is less than zero even when it has not
>> been updated. Since these checks are redundant we can remove these
>> as well as err and the error exit label err_exit.
>>
>> Detected by CoverityScan, CID#1398313 and CID#1398306 ("Logically
>> dead code")
>>
>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> 
> Please enhance your commit message to also explain that the functions
> being called around these checks all return void, to make it clear
> that this isn't an issue of the return values not being checked.
> 
> Thanks.
> 
Good idea. Will do.
