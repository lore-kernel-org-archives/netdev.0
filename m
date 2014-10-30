From: David Miller <davem@davemloft.net>
Subject: Re: Mistake in commit 0d961b3b52f566f823070ce2366511a7f64b928c
 breaks cpsw non dual_emac mode.
Date: Thu, 30 Oct 2014 15:43:23 -0400 (EDT)
Message-ID: <20141030.154323.1702996635200338108.davem@davemloft.net>
References: <20141028170242.GA24112@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, hs@denx.de, mugunthanvnm@ti.com,
	netdev@vger.kernel.org
To: lsorense@csclub.uwaterloo.ca
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141028170242.GA24112@csclub.uwaterloo.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Lennart Sorensen" <lsorense@csclub.uwaterloo.ca>
Date: Tue, 28 Oct 2014 13:02:42 -0400

> I believe commit 0d961b3b52f566f823070ce2366511a7f64b928c made a mistake
> while correcting a bug.

This patch submission is not properly formed.

You subject line should be of the form:

subsystem: Description.

"subsystem" here would be "cpsw: " or something like that.

Secondly, you should not refer to a commit ID in the patch
Subject line, instead just describe exactly what is being
fixed in the most succinct yet complete manner that is
possible.

Thirdly, when you do refer to commit ID's in your commit
message body you must do so in the following format:

${SHA1_ID} ("Commit message header line text.")

The commit message body is also not a place to have a general
discussion.  Please avoid saying things like "I think", for example.
State facts, and be exact about what the problem is and exactly
how you are fixing it.

Because this commit message will be read by others looking at your
change days, weeks, years from now.

Thanks.
