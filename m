From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: e100 "Ferguson" release
Date: Sun, 03 Aug 2003 02:12:49 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2CA7E1.6060800@pobox.com>
References: <C6F5CF431189FA4CBAEC9E7DD5441E010222927D@orsmsx402.jf.intel.com> <3F2CA65F.8060105@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Feldman, Scott" <scott.feldman@intel.com>
In-Reply-To: <3F2CA65F.8060105@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> * (extremely minor) some people (like me :)) consider dead reads like 
> the readb() call in e100_write_flush

er, that was a bit incomplete.

completing:

  ... needing to be marked explicitly with a "(void) " prefix, 
indicating it is intentionally a dead read.

Maintainer's call, ultimately, though...
