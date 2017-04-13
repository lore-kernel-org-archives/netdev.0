From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH v2] mac80211: Fix clang warning about constant operand
 in logical operation
Date: Thu, 13 Apr 2017 08:27:30 +0200
Message-ID: <1492064850.19193.6.camel@sipsolutions.net>
References: <20170406233141.123098-1-mka@chromium.org>
         (sfid-20170407_013202_907352_DB786B38)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org, Grant Grundler <grundler@chromium.org>,
        Michael Davidson <md@google.com>,
        Greg Hackmann <ghackmann@google.com>
To: Matthias Kaehlcke <mka@chromium.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170406233141.123098-1-mka@chromium.org> (sfid-20170407_013202_907352_DB786B38)
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-04-06 at 16:31 -0700, Matthias Kaehlcke wrote:
> When clang detects a non-boolean constant in a logical operation it
> generates a 'constant-logical-operand' warning. In
> ieee80211_try_rate_control_ops_get() the result of strlen(<const
> str>)
> is used in a logical operation, clang resolves the expression to an
> (integer) constant at compile time when clang's builtin strlen
> function
> is used.
> 
> Change the condition to check for strlen() > 0 to make the constant
> operand boolean and thus avoid the warning.
> 
Applied.

johannes
