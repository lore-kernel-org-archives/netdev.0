From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] isdn: hisax: set error code on failure
Date: Sun, 4 Dec 2016 13:40:48 +0300
Message-ID: <7d61be6f-ef55-acd6-da54-a8171631826f@cogentembedded.com>
References: <1480847603-15520-1-git-send-email-bianpan201603@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Pan Bian <bianpan2016@163.com>
To: Pan Bian <bianpan201603@163.com>,
        Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1480847603-15520-1-git-send-email-bianpan201603@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 12/4/2016 1:33 PM, Pan Bian wrote:

   You now need to indicate the patch version in hte subject, like this:

[PATCH 1/1 v2] isdn:...

> From: Pan Bian <bianpan2016@163.com>
>
> In function hfc4s8s_probe(), the value of return variable err should be
> negative on failures. However, when the call to request_region() returns
> NULL, the value of err is 0. This patch fixes the bug, assiging

    Assigning.

> "-EBUSY" to err on the path that request_region() fails.
>
> Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=188931
>
> Signed-off-by: Pan Bian <bianpan2016@163.com>
> ---

    And here you're supposed to describe changes in the different patch 
versions...

[...]

MBR, Sergei
