From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Wed, 13 Dec 2006 17:47:41 +0100
Message-ID: <200612131747.42035.IvDoorn@gmail.com>
References: <200612031919.05228.IvDoorn@gmail.com> <a32f33a40612090505j23251626k891edae1c06b6fb2@mail.gmail.com> <20061213154415.GA26415@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Michael Wu <flamingice@sourmilk.net>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:7583 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965028AbWLMQr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Dec 2006 11:47:57 -0500
Received: by nf-out-0910.google.com with SMTP id o25so569581nfa
        for <netdev@vger.kernel.org>; Wed, 13 Dec 2006 08:47:55 -0800 (PST)
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
In-Reply-To: <20061213154415.GA26415@csclub.uwaterloo.ca>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 13 December 2006 16:44, Lennart Sorensen wrote:
> On Sat, Dec 09, 2006 at 02:05:06PM +0100, Ivo Van Doorn wrote:
> > Nope, don't have that device. I'll create a patch that will place the eeprom
> > module in the /lib folder. I'll send that to the list as soon as possible.
> 
> Hmm, I wonder if this will be of help for me trying to read/write a
> 93c46 connected to an exar uart (jsm driver).  So far I was trying to
> bit bang the IO from user space through the PCI registers, but having a
> proper support in the driver would probably work better (so far I didn't
> get it to work although I haven't tried very hard yet).

Do you need to actually write data to the eeprom chip?
Currently the module does not support writing to the eeprom,
this is something I could add (The original Ralink code, where this module
is based on also contains the code to write to the EEPROM).

Ivo
