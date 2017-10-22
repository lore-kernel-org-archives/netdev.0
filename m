From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [MERGE README] net --> net-next
Date: Sun, 22 Oct 2017 15:09:11 +0200
Message-ID: <59EC9877.6080702@iogearbox.net>
References: <20171022.135717.971703426919688431.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, john.fastabend@gmail.com
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:50262 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751142AbdJVNJN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 22 Oct 2017 09:09:13 -0400
In-Reply-To: <20171022.135717.971703426919688431.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/22/2017 02:57 PM, David Miller wrote:
>
> There were quite a few BPF conflicts during the merge I just did of
> 'net' into 'net-next'.
>
> In particular, all of the packet pointer branch tests in the verifier
> had to be resolved wrt. three different sets of changes.
>
> The off-by-one stuff.  The allowance of the 'data_end > ptr + x' form
> of packet pointer checks.  And finally, the metadata stuff.
>
> I would really appreciate an audit and double check of my merge work
> by the interested parties.

I will do a review today in the evening, thanks David!
