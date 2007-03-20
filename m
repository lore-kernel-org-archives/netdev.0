From: "Alexey Dobriyan" <adobriyan@gmail.com>
Subject: Re: [RFC][PATCH -mm take3 2/6][resend] support multiple logging
Date: Tue, 20 Mar 2007 14:34:29 +0200
Message-ID: <b6fcc0a0703200534w179a664dk6bfc6108879bde94@mail.gmail.com>
References: <45FFCF31.3040000@bx.jp.nec.com> <45FFD2E5.9070208@bx.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Keiichi KII" <k-keiichi@bx.jp.nec.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933133AbXCTMee@vger.kernel.org>
In-Reply-To: <45FFD2E5.9070208@bx.jp.nec.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/20/07, Keiichi KII <k-keiichi@bx.jp.nec.com> wrote:
> This patch contains the following changes for supporting multiple logging
>  agents.

> +#define CONFIG_SEPARATOR ";"

CONFIG_* is reserved for configuration options. Since you use
it in only one place just use semicolon directly.
