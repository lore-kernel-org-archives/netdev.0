From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: RFR: new SiS gige driver
Date: Fri, 8 Aug 2003 12:01:50 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030808120150.45f091d8.shemminger@osdl.org>
References: <20030808173932.GA4077@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20030808173932.GA4077@gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Comments:
	- Run through lindent, indenting is non-standard.

	- struct board_info defined but only used in one debug message
	  and it is just a string.

	- C99 initializers?

	- if code is commented out and outdated remove it (see init_board)

	- poisoning memory is useless and done already by allocator
	  (see SIS190_remove_one)

	- assert checks for null pointers are overkill

	- ethtool?

Overall, suffers a little from the "having more debug code makes my
driver more reliable" fallacy.
