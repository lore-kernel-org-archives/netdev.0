From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH]  New Chapter on CodingStyle .
Date: Sat, 12 Aug 2017 08:54:39 -0600
Message-ID: <20170812085439.573c6c55@lwn.net>
References: <1502536998-5482-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Realtek linux nic maintainers <nic_swsd@realtek.com>
To: Corcodel Marian <asd@marian1000.go.ro>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1502536998-5482-1-git-send-email-asd@marian1000.go.ro>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2017 14:23:18 +0300
Corcodel Marian <asd@marian1000.go.ro> wrote:

> ---
>  Documentation/CodingStyle | 28 ++++++++++++++++++++++++++++
>  1 file changed, 28 insertions(+)
> 
> diff --git a/Documentation/CodingStyle b/Documentation/CodingStyle
> index 9a70ddd..864dd8b 100644
> --- a/Documentation/CodingStyle
> +++ b/Documentation/CodingStyle
> @@ -922,6 +922,34 @@ expression used.  For instance:
>  	...
>  	#endif /* CONFIG_SOMETHING */
>  
> +		Chapter 20: Put values on initialisers without exception
> +
> +When declaring variables on functions must put values:

Thanks for sending a patch for the kernel's documentation.
Unfortunately, I can't accept this patch for a couple of reasons:

- Kernel patches must include a changelog describing *why* the change is
  being made and a proper signoff line.  See
  Documentation/process/submitting-patches.rst for details.

- The coding style document is there to describe the community's
  standards for kernel code.  It is *not* a mechanism for imposing new
  standards.  If you really think that the kernel community should adopt
  this rule, you will need to argue for it on the mailing lists.  I will
  say, though, that I do not expect that this effort would be successful.

Can I make a suggestion?  If you have found kernel functions with bugs
related to use of uninitialized variables, please submit fixes for those
specific bugs, along with a clear description of how the bug happens and
what its effects are.

Thanks,

jon
