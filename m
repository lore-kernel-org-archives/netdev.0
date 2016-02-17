From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] lance: Return correct error code
Date: Wed, 17 Feb 2016 17:16:21 +0300
Message-ID: <56C480B5.7000902@cogentembedded.com>
References: <20160217133516.GA31497@amitoj-Inspiron-3542>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr
To: Amitoj Kaur Chawla <amitoj1606@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160217133516.GA31497@amitoj-Inspiron-3542>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 2/17/2016 4:35 PM, Amitoj Kaur Chawla wrote:

> The return value of kzalloc on failure should be -ENOMEM and

    kzalloc() returns NULL on failure! You need to clarify your patch 
description, so that it makes some sense.

> not -ENODEV.
>
> Additionally, removed the following checkpatch warnings:
> ERROR: spaces required around that '==' (ctx:VxV)
> ERROR: space required before the open parenthesis '('
> CHECK: Comparison to NULL could be written "!lp"
>
> Signed-off-by: Amitoj Kaur Chawla <amitoj1606@gmail.com>
[...]

MBR, Sergei
